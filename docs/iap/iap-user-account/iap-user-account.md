```
$ curl "https://kuard.gogke-test-7.damlys.pl/healthy"
Invalid IAP credentials: empty token

$ curl -H "Authorization: Bearer $(gcloud auth print-access-token)" "https://kuard.gogke-test-7.damlys.pl/healthy"
Invalid IAP credentials: Unable to parse JWT

$ curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" "https://kuard.gogke-test-7.damlys.pl/healthy"
Invalid IAP credentials: Invalid bearer token. Invalid JWT audience.
```

encoded JWT:

```
X-Goog-Authenticated-User-Email: accounts.google.com:damian.lysiak@gmail.com
X-Goog-Authenticated-User-Id: accounts.google.com:100655719484696733869
X-Goog-Iap-Jwt-Assertion: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlM3X3FkUSJ9.eyJhdWQiOiIvcHJvamVjdHMvNzY0MDg2MjE5MTY1L2dsb2JhbC9iYWNrZW5kU2VydmljZXMvNTI0NDM3MTcwNTM3ODkzOTQ3OCIsImF6cCI6Ii9wcm9qZWN0cy83NjQwODYyMTkxNjUvZ2xvYmFsL2JhY2tlbmRTZXJ2aWNlcy81MjQ0MzcxNzA1Mzc4OTM5NDc4IiwiZW1haWwiOiJkYW1pYW4ubHlzaWFrQGdtYWlsLmNvbSIsImV4cCI6MTczODA4MDQ0MSwiaWF0IjoxNzM4MDc5ODQxLCJpZGVudGl0eV9zb3VyY2UiOiJHT09HTEUiLCJpc3MiOiJodHRwczovL2Nsb3VkLmdvb2dsZS5jb20vaWFwIiwic3ViIjoiYWNjb3VudHMuZ29vZ2xlLmNvbToxMDA2NTU3MTk0ODQ2OTY3MzM4NjAifQ.MhTxfwmE8D8nEKwLyt0HVGXLniSJ3ZkzpP77svA94XBqlGpaI0PVA9qqO7kLQrOc1acAKVsv6wQ-vQGjfsbRWQ
```

decoded JWT:

```json
{
  "aud": "/projects/764086219165/global/backendServices/5244371705378939478",
  "azp": "/projects/764086219165/global/backendServices/5244371705378939478",
  "email": "damian.lysiak@gmail.com",
  "exp": 1738080441,
  "iat": 1738079841,
  "identity_source": "GOOGLE",
  "iss": "https://cloud.google.com/iap",
  "sub": "accounts.google.com:100655719484696733869"
}
```
