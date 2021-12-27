package pr

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/google/go-github/v41/github"
	"golang.org/x/oauth2"
)

var _ Provider = (*GitHub)(nil)

type GitHub struct {
	client *github.Client
}

type GitHubConfig struct {
	PAT string
}

func NewGitHubProvider(cfg *GitHubConfig) (*GitHub, error) {
	var httpClient *http.Client
	if cfg != nil && cfg.PAT != "" {
		ts := oauth2.StaticTokenSource(
			&oauth2.Token{AccessToken: cfg.PAT},
		)
		httpClient = oauth2.NewClient(context.Background(), ts)
	}

	client := github.NewClient(httpClient)

	return &GitHub{
		client: client,
	}, nil
}

func ownerRepoFromID(repoID string) (string, string, error) {
	split := strings.Split(repoID, "/")
	if len(split) != 2 {
		return "", "", errors.New("malformed repoID")
	}

	return split[0], split[1], nil
}

func (g GitHub) GetPRsForRepo(ctx context.Context, repoID string) ([]PR, error) {
	owner, repo, err := ownerRepoFromID(repoID)
	if err != nil {
		return nil, err
	}
	pullrequests, _, err := g.client.PullRequests.List(ctx, owner, repo, nil)
	if err != nil {
		return nil, err
	}

	prs := make([]PR, 0, len(pullrequests))
	for _, pullrequest := range pullrequests {
		prs = append(prs, PR{
			Title: pullrequest.GetTitle(),
			URL:   pullrequest.GetHTMLURL(),
		})
	}

	return prs, nil
}
