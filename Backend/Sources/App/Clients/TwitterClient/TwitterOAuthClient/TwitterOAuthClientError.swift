import TwitterAPIKit

/// Represents errors that can occur during Twitter OAuth authentication flow
enum TwitterOAuthClientError: Error {
    /// Error returned from Twitter API request
    case responseError(TwitterAPIKitError)
    
    /// Unknown error occurred during OAuth process
    case unknown(error: Error)
    
    /// Failed to construct the Twitter authentication URL
    case unableToMakeAuthenticateURL
    
    /// The OAuth token is invalid or missing required data
    case invalidOAuthToken
}
