local Create = require("./Create")

return function(animator: Animator, animations: { [string]: string }): { [string]: AnimationTrack }
	local animationTracks = {}
	for name, animationId in animations do
		animationTracks[name] = animator:LoadAnimation(Create("Animation")({
			AnimationId = animationId,
		}))
	end
	return animationTracks
end
