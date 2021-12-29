package api

import (
	"context"

	dashboardv1 "github.com/brumhard/pr-dashboard/pkg/pb/dashboard/v1"
	"github.com/brumhard/pr-dashboard/pkg/pr"
)

var _ dashboardv1.DashboardServiceServer = (*GRPC)(nil)

type GRPC struct {
	dashboardv1.UnimplementedDashboardServiceServer
	service *pr.Aggregator
}

func NewGRPC(service *pr.Aggregator) *GRPC {
	return &GRPC{service: service}
}

func (g *GRPC) ListPullRequests(ctx context.Context, request *dashboardv1.ListPullRequestsRequest) (*dashboardv1.ListPullRequestsResponse, error) {
	prs, err := g.service.GetAllPRs(ctx)
	if err != nil {
		return nil, err
	}

	pullrequests := make([]*dashboardv1.PullRequest, 0, len(prs))
	for _, pullrequest := range prs {
		pullrequests = append(pullrequests, &dashboardv1.PullRequest{
			Title: pullrequest.Title,
			Url:   pullrequest.URL,
		})
	}
	return &dashboardv1.ListPullRequestsResponse{
		Items: pullrequests,
	}, nil
}