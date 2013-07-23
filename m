From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Tue, 23 Jul 2013 15:39:10 -0400
Message-ID: <CAOS58YPEKtEiZWsn-8u6OPr-UsyQp=XR+ecGmXyOdT0JnYAmsA@mail.gmail.com>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org> <20130723183841.GA9021@tp>
	<CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA@mail.gmail.com>
	<20130723190426.GA9577@tp> <20130723191245.GI21100@mtj.dyndns.org>
	<20130723192801.GA9923@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130723192801.GA9923@tp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Serge.

On Tue, Jul 23, 2013 at 3:28 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>> Well, that also is the exact type of priv delegation we're moving away
>> from, so....
>
> I think that's unreasonable, but I guess I'll have to go reread the
> old thread.

Yeah, please do. I think the case is pretty strong for disallowing
delegation of cgroup directories to !root (or whatever CAP it should
be) users. It's inherently unsafe for some controllers and ends up
leaking kernel implementation details into regular binaries thus
cementing those leaked details as APIs, which is a giant no-no.

> If we have decent enforcement of hierarchy for devices.{allow,deny},
> which we now do, then I don't see why this has to be the case.

If you think about devcg in isolation, maybe, but please keep in mind
that devcg itself is already somewhat abusing cgroup and many other
controllers shouldn't be allowed to delegate and we're headed for one
unified hierarchy.

>> kinda moot point.  If there are people actually doing that in the
>> wild, we can conditionalize it on cgroup_sane_behavior().
>
> Guess we'll stop using cgroups for now.

If you're delegating cgroup accesses to !root users, yes, STOP,
please. It'd be doing a lot more harm to the whole kernel and its
maintainability than whatever extra features / benefits it may be
bringing.

Thanks.

--
tejun
