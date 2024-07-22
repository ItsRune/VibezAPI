type successfulResponse<T> = {
	success: boolean,
	message: string,
	data: T,
}

type errorResponse = {
	success: boolean,
	message: string,
}

type Response<T> = errorResponse | successfulResponse<T>
type User = Player | string | number

export type rankingModule = {
	setRank: (self: rankingModule, userId: User, newRank: number | string) -> Response<{ any }>,
	Promote: (self: rankingModule, userId: User) -> Response<nil>,
	Fire: (self: rankingModule, userId: User) -> Response<nil>,
	Demote: (self: rankingModule, userId: User) -> Response<nil>,
}

return nil
