package kuard

import (
	"net/http"
	"testing"
)

func TestSuccess(t *testing.T) {
	requestUrl := "https://stateless-kuard.gogke-test-2.damlys.dev/-/env"
	statusCode := http.StatusOK

	req, err := http.NewRequest("GET", requestUrl, nil)
	if err != nil {
		t.Fatalf("could not create request: %v", err)
	}

	client := &http.Client{}
	res, err := client.Do(req)
	if err != nil {
		t.Fatalf("could not send request: %v", err)
	}
	defer res.Body.Close()

	if res.StatusCode != statusCode {
		t.Errorf("expected status %v, got %v", statusCode, res.StatusCode)
	}
}

func TestRedirects(t *testing.T) {
	testcases := [...]struct {
		requestUrl  string
		redirectUrl string
		statusCode  int
	}{
		{
			"http://stateless-kuard.gogke-test-2.damlys.dev/-/env",
			"https://stateless-kuard.gogke-test-2.damlys.dev/-/env",
			http.StatusFound,
		},
		{
			"https://kuard.gogke-test-2.damlys.dev/-/env",
			"https://stateless-kuard.gogke-test-2.damlys.dev/-/env",
			http.StatusMovedPermanently,
		},
	}

	for _, tc := range testcases {
		req, err := http.NewRequest("GET", tc.requestUrl, nil)
		if err != nil {
			t.Fatalf("could not create request: %v", err)
		}

		client := &http.Client{
			// do not follow redirects
			CheckRedirect: func(req *http.Request, via []*http.Request) error {
				return http.ErrUseLastResponse
			},
		}
		res, err := client.Do(req)
		if err != nil {
			t.Fatalf("could not send request: %v", err)
		}
		defer res.Body.Close()

		if res.StatusCode != tc.statusCode {
			t.Errorf("expected status %v, got %v (%s)", tc.statusCode, res.StatusCode, tc.requestUrl)
		}

		if got := res.Header.Get("location"); got != tc.redirectUrl {
			t.Errorf("expected URL %s, got %s", tc.redirectUrl, got)
		}
	}
}
