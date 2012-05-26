From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] user namespace enhancements for Linux 3.5-rc1
Date: Sat, 26 May 2012 09:30:39 -0600
Message-ID: <87k3zzt0ww.fsf@xmission.com>
References: <87hav8vypc.fsf@xmission.com> <1337894526.9093.7.camel@lenny>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1337894526.9093.7.camel@lenny> (Colin Walters's message of "Thu,
	24 May 2012 17:22:06 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org> writes:

> On Tue, 2012-05-22 at 12:48 -0600, Eric W. Biederman wrote:
>
>> My git tree covers all of the modifications needed to convert the core
>> kernel and enough changes to make a system bootable to runlevel 1.
>
> What system?  I'm curious about the state of your userspace
> modifications.

Debian.

Userspace won't need any modifications to work, but I am slowly working
through the patches needed to get everything in the kernel converted.
And my patches for the networking stack weren't quite ready for the
merge window.

Ultimately to be included in distro kernels and really be useful I need
to make everything in the kernel that plays with uids and gids user
namespace aware so that is my goal for the next merge window.  We will
see how that goes.

As for patches to userspace, all I think I will need is a small change
to useradd, and perhaps a helper function to validate the mapping into
the initial user namespace's uids. Aka is user A allowed to use uids
100,000-110,000?

I have a branch in my user-namespace.git with all of the rest of my
kernel changes if you want to play.  Beyond that I expect most of the
user space changes (useradd etc) to land in ubuntu fairly shortly
after they are viable as I am working closely with a couple folks
at ubunut.

Eric
