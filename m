From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Wed, 01 Nov 2017 12:20:52 -0500
Message-ID: <87h8udj4p7.fsf__17483.5233403885$1509556903$gmane$org@xmission.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com> <87k1zaswu6.fsf_-_@xmission.com>
	<143adb61-fb8e-fc1b-396b-b18836e68766@suse.com>
	<87a806ntn0.fsf@xmission.com> <1509555601.31043.44.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1509555601.31043.44.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> (Joe Perches's message of
	"Wed, 01 Nov 2017 10:00:01 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: tycho-E0fblnxP3wo@public.gmane.org, Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> On Wed, 2017-11-01 at 06:08 -0500, Eric W. Biederman wrote:
>> I won't listen to checkpatch when it is wrong.
>
> Always a good idea.
>
> btw: what is checkpatch wrong about this time?

Well the way I was hearing the conversation was that there was a patch
that fixed a real bug, but it was wrong because checkpatch complained
about it.

So I don't even know if the warning is a problem.  But blocking bug
fixes because there is a warning certainly is.

If someone wants to change coding style in practice so that every
smp_rmb and every smp_wmb has detailed comments that everyone must
include they need to follow the usual rule and update the entire kernel
when making an interface change.  As that did not happen I don't see
any problems with incremental updates in the style the code is already
in.

Not that I will mind a patch that updates the code, but I am not going
to hold up a perfectly good bug fix waiting for one either.

Eric
