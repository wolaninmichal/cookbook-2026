//
//  URLSessionHTTPClient.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    init(session: URLSession = .init(configuration: .default)) {
        self.session = session
    }

    func send<Response: Decodable>(
        _ endpoint: Endpoint,
        decoder: JSONDecoder = JSONCoding.decoder,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        perform(endpoint, body: nil) { result in
            completion(result.flatMap { data in
                Self.decode(Response.self, from: data, decoder: decoder)
            })
        }
    }
    func send<Body: Encodable, Response: Decodable>(
        _ endpoint: Endpoint,
        body: Body,
        encoder: JSONEncoder = JSONCoding.encoder,
        decoder: JSONDecoder = JSONCoding.decoder,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        do {
            let data = try encoder.encode(body)
            perform(endpoint, body: data) { result in
                completion(result.flatMap { data in
                    Self.decode(Response.self, from: data, decoder: decoder)
                })
            }
        } catch {
            completion(.failure(NetworkError.encoding(error)))
        }
    }

    func send(
        _ endpoint: Endpoint,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        perform(endpoint, body: nil) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body,
        encoder: JSONEncoder = JSONCoding.encoder,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let data = try encoder.encode(body)
            perform(endpoint, body: data) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(NetworkError.encoding(error)))
        }
    }

    // MARK: - Core
    private func perform(
        _ endpoint: Endpoint,
        body: Data?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let request: URLRequest
        do {
            request = try URLRequestBuilder(endpoint: endpoint).createURLRequest(body: body)
        } catch {
            completion(.failure(error))
            return
        }

        NetworkLogger.logRequest(request, body: body)

        let task = session.dataTask(with: request) { data, response, error in

            NetworkLogger.logResponse(response as? HTTPURLResponse, data: data, error: error)

            if let error {
                completion(.failure(NetworkError.transport(error)))
                return
            }

            guard let http = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200...299).contains(http.statusCode) else {
                completion(.failure(NetworkError.httpStatus(http.statusCode, body: data)))
                return
            }

            completion(.success(data ?? Data()))
        }
        task.resume()
    }

    private static func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder
    ) -> Result<T, Error> {
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch {
            return .failure(NetworkError.decoding(error))
        }
    }
}

