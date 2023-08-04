
# GraphQL Client

[![License](https://img.shields.io/cocoapods/l/LFTwitterProfile.svg?style=flat)](http://cocoapods.org/pods/LFTwitterProfile)
[![Platform](https://img.shields.io/cocoapods/p/LFTwitterProfile.svg?style=flat)](http://cocoapods.org/pods/LFTwitterProfile)

It is a open source framework to connect servers supporting GraphQL for IOS.

## Usage:
To use this framework, a graphql file is required. We used a sample graphql file from sample server as https://spacex-production.up.railway.app/ .
Create a text file into your xcode project. Add own GraphQL query code.

Sample File:
``` GraphQL
query ($name: String!) {
  __type(name: $name) {
    name
  }
}
```

Add fallowing code in cocapods file and run "pod update" on Terminal.


`pod 'GraphQLClient', :git => "https://github.com/SerkanHocam/GraphQL_Client.git"`


Create an instance and set your own value.

```swift
guard let url = URL(string: "https://spacex-production.up.railway.app/") else { return }

let instance = GraphQL(baseUrl: url)

let queryFile = "SampleQuery.graphQL"
let sampleParams = [ "name": "users" ]

instance.fetchJson(queryFileName: queryFile, parameters: sampleParams) { json, error in

    if let err = error {
      print(err)
    } else if let js = json as? [String:Any] {
      print(js.description)
    }
}
```

It also return data for mapping frameworks by following method.

```swift
instance.fetchData(queryFileName: queryFile, parameters: sampleParams) { data, error in

    if let err = error {
      print(err)
    } else if let dt = data, let str = String(data: dt, encoding: .utf8) {
      print(str)
    }
}
```

In case of server needs Authorization, set authorization information to authorization property according to server security protocol.

```swift
guard let url = URL(string: "https://spacex-production.up.railway.app/") else { return }

let instance = GraphQL(baseUrl: url)

instance.authorization = [ "userName": "x", "password":"123" ]

...
```

## Supported versions & requirements:

- Swift 5+
- iOS 13+
- Xcode 14+

## Features

- Include GraphQL server authorization rules. 
- Support GraphQL http body and header format.



