From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: netns34
Date: Tue, 07 Aug 2007 16:17:23 -0600
Message-ID: <m1wsw7f0r0.fsf@ebiederm.dsl.xmission.com>
References: <m11wefgfl0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11wefgfl0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric W. Biederman's
	message of "Tue, 07 Aug 2007 16:11:39 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>, Daniel Lezcano <dlezcano-juSfH4iHXoxBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Ok.  After a bunch of work I have my network namespace patches working
> again against 2.6.23-rc2 or whatever is linus's latest.
>
> I need to break out my sysctl work and send that separately.
>
> I need to get veth in there and I need to get a patch to /sbin/ip
> to work with Patrick McHardy's form of patches.
>
> But I think I am quickly approaching the point where I will have
> patches ready for merging.
>
> Once I get sysctl sorted out I will start post a minimal patchset
> for prereview and see where things go.
>
> Hopefully my sysfs work finally sticks this time.

And the important part the code will shortly be available at:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git#netns/v2.6.23-rc2netns34

And also from the default head.

Eric
