From: "Brian K. White" <brian-goxB3+SAe6wAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 03 Nov 2011 16:13:03 -0400
Message-ID: <4EB2F5CF.5010604@aljex.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<4EB2C4A5.6000406@parallels.com>
	<20111103165903.GA4755@Debian-60-squeeze-64-minimal>
	<20111103182101.5037c1e5@lxorguk.ukuu.org.uk>
	<20111103185108.GA5153@Debian-60-squeeze-64-minimal>
	<20111103190330.02590426@lxorguk.ukuu.org.uk>
	<20111103192039.GA5300@Debian-60-squeeze-64-minimal>
	<4EB2EA93.2050206@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4EB2EA93.2050206-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/3/2011 3:25 PM, Glauber Costa wrote:
> On 11/03/2011 05:20 PM, Max Kellermann wrote:
>> On 2011/11/03 20:03, Alan Cox<alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> wrote:
>>> Sure - I'm just not seeing that a whole separate cgroup for it is
>>> appropriate or a good plan. Anyone doing real resource management needs
>>> the rest of the stuff anyway.
>>
>> Right. When I saw Frederic's controller today, my first thought was
>> that one could move the fork limit code over into that controller. If
>> we reach a consensus that this would be a good idea, and would have
>> chances to get merged, I could probably take some time to refactor my
>> code.
>>
>> Max
> I'd advise you to take a step back and think if this is really needed.
> As Alan pointed out, the really expensive resource here is already being
> constrained by Frederic's controller.

I think this really is a different knob that is nice to have as long as 
it doesn't cost much. It's a way to set a max lifespan in a way that 
isn't really addressed by the other controls. (I could absolutely be 
missing something.)

I think Max explained the issue clearly enough.

It doesn't matter that the fork itself is supposedly so cheap.

It's still nice to have a way to say, you may not fork/die/fork/die/fork 
in a race.

What's so unimaginable about having a process that you know needs a lot 
of cpu and ram or other resources to do it's job, and you expressly want 
to allow it to take as much of those resources as it can, but you know 
it has no need to fork, so if it forks, _that_ is the only indication of 
a problem, so you may only want to block it based on that.

Sure many other processes would legitimately fork/die/fork/die a lot 
while never exceeding a few total concurrent tasks, and for them you 
would not want to set any such fork limit. So what?

-- 
bkw
