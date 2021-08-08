//
//  KeyedCodingExtensions.swift
//  KeyedCodingExtensions
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation

extension KeyedEncodingContainerProtocol {
    mutating func encode(bookmarkForURL url: URL, options: URL.BookmarkCreationOptions, forKey key: Self.Key) throws {
        let data = try url.bookmarkData(options: options, includingResourceValuesForKeys: nil, relativeTo: nil)
        try encode(data, forKey: key)
    }
    
    mutating func encodeIfPresent(bookmarkForURL url: URL?, options: URL.BookmarkCreationOptions, forKey key: Self.Key) throws {
        guard let url = url else {
            return
        }
        
        let data = try url.bookmarkData(options: options, includingResourceValuesForKeys: nil, relativeTo: nil)
        try encode(data, forKey: key)
    }
}

extension KeyedDecodingContainerProtocol {
    func decodeURLFromBookmark(options: URL.BookmarkResolutionOptions, forKey key: Self.Key, stale: inout Bool) throws -> URL {
        let data = try decode(Data.self, forKey: key)
        return try URL(resolvingBookmarkData: data, options: options, relativeTo: nil, bookmarkDataIsStale: &stale)
    }
    
    func decodeURLFromBookmarkIfPresent(options: URL.BookmarkResolutionOptions, forKey key: Self.Key, stale: inout Bool) throws -> URL? {
        guard let data = try decodeIfPresent(Data.self, forKey: key) else {
            return nil
        }
        
        return try URL(resolvingBookmarkData: data, options: options, relativeTo: nil, bookmarkDataIsStale: &stale)
    }
}
