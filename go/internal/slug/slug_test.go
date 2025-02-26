package slug

import "testing"

func TestMake(t *testing.T) {
	testcases := [...]struct {
		text string
		want string
	}{
		{"", ""},

		{"foo", "foo"},
		{"foo-bar", "foo-bar"},
		{"foo_bar", "foo-bar"},
		{"foo--bar", "foo-bar"},
		{"foo__bar", "foo-bar"},

		{"foo/bar", "foo-bar"},
		{"foo/bar/baz", "foo-bar-baz"},
		{"foo/bar/.baz", "foo-bar-baz"},

		{"foo/bar_baz--qux", "foo-bar-baz-qux"},
		{"foo1/bar2_ba3z--4qux", "foo1-bar2-ba3z-4qux"},
	}

	for _, tc := range testcases {
		if got := Make(tc.text); got != tc.want {
			t.Errorf("Make(%s) = %s, wanted %s", tc.text, got, tc.want)
		}
	}
}
