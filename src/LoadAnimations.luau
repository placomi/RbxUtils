local Create = require("./Create")

return function(animator: Animator, animations: { [string]: string | Animation }): { [string]: AnimationTrack }
	local animationTracks = {}
	for name, animationData in animations do
		if typeof(animationData) == "Instance" then
			animationTracks[name] = animator:LoadAnimation(animationData)
		else
			animationTracks[name] = animator:LoadAnimation(Create("Animation")({
				AnimationId = animationData,
			}))
		end
	end
	return animationTracks
end
