import TwitterAPIKit

/// Errors that can occur when making authenticated requests to the Twitter API
enum TwitterAuthenticatedClientError: Error {
    /// An error occurred while processing the Twitter API response
    /// - Parameter error: The underlying TwitterAPIKit error
    case responseError(TwitterAPIKitError)
    
    /// The Twitter API response was empty or nil when data was expected
    case responseEmpty
}