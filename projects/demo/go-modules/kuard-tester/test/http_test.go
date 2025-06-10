package test

import (
	"net/http"
	"testing"
)

func TestSuccess(t *testing.T) {
	req, err := http.NewRequest("GET", "https://stateless-kuard.gogke-test-3.damlys.dev/-/env", nil)
	if err != nil {
		t.Fatalf("request create error: %v", err)
	}

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		t.Fatalf("request send error: %v", err)
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		t.Errorf("response status code: %d, wanted: %d", res.StatusCode, http.StatusOK)
	}
}

func TestRedirects(t *testing.T) {
	testcases := [...]struct {
		name        string
		requestUrl  string
		redirectUrl string
		statusCode  int
	}{
		{
			"http to https redirect",
			"http://stateless-kuard.gogke-test-3.damlys.dev/-/env",
			"https://stateless-kuard.gogke-test-3.damlys.dev/-/env",
			http.StatusFound,
		},
		{
			"old domain redirect",
			"https://kuard.gogke-test-3.damlys.dev/-/env",
			"https://stateless-kuard.gogke-test-3.damlys.dev/-/env",
			http.StatusMovedPermanently,
		},
	}

	for _, tc := range testcases {
		t.Run(tc.name, func(t *testing.T) {
			req, err := http.NewRequest("GET", tc.requestUrl, nil)
			if err != nil {
				t.Fatalf("request create error (%s): %v", tc.requestUrl, err)
			}

			client := &http.Client{
				// do not follow redirects
				CheckRedirect: func(req *http.Request, via []*http.Request) error {
					return http.ErrUseLastResponse
				},
			}
			res, err := client.Do(req)
			if err != nil {
				t.Fatalf("request send error (%s): %v", tc.requestUrl, err)
			}
			defer res.Body.Close()

			if res.StatusCode != tc.statusCode {
				t.Errorf("response status code (%s): %d, wanted: %d", tc.requestUrl, res.StatusCode, tc.statusCode)
			}

			if got := res.Header.Get("location"); got != tc.redirectUrl {
				t.Errorf("response redirect URL (%s): %s, wanted: %s", tc.requestUrl, got, tc.redirectUrl)
			}
		})
	}
}
