From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow directory
	support.
Date: Sun, 22 Jul 2007 16:19:42 -0600
Message-ID: <m17iosw075.fsf@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>
	<20070621211637.GB10583@suse.de>
	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>
	<20070622001328.GA14113@suse.de>
	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>
	<20070625212339.GA13398@kroah.com>
	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>
	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>
	<46A3B449.3090409@gmail.com> <20070722202508.GA18018@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070722202508.GA18018-l3A5Bk7waGM@public.gmane.org> (Greg KH's message of "Sun, 22
	Jul 2007 13:25:08 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> writes:

> On Mon, Jul 23, 2007 at 04:47:21AM +0900, Tejun Heo wrote:
>> Sorry but I don't think the current approach is the correct one.  It's
>> too painful and too much complexity is scattered all over the place.
>> I'm afraid this implementation is going to be a maintenance nightmare.
>
> In looking over this again, and due to the fact that there are no
> in-kernel users of this code, I'm going to drop the other patches in
> this series and only keep the first one that removes the current
> implementation.
>
> Eric, is that ok?  It gives you time to revisit these changes.

Greg a big part of the reason I don't have internal kernel users
is keeping up with changes of sysfs has meant I haven't had time
to clean up and submit the patches for the users.  With a little
luck I will have users by 2.6.24.  I am in the process of cleaning
up those patches right now.  So I can send the off to Dave Miller.

So please can we try and at least keep these sysfs patches in a
development tree so that people will see them.

Further while there are a few little nits I think mostly Tejun is 
mostly objecting to the fundamental complexity of the problem rather
then to things that can be fixed by a cleaner implementation.

If it didn't take me a week every time I had to update this code
after Tejun changes the locking rules in fs/sysfs/dir.c or if there
was someone I could delegate the work of maintaining this code to
I probably would not mind dropping the patches for a little bit.  As
it stands I am having horrible nightmares about how the internals
of sysfs will be completely different if you drop the last 3 patches
by the time I come back and I will need to spend several more weeks
just catching up.

Eric
