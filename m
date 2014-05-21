From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Containers over 9p in 3.14
Date: Wed, 21 May 2014 14:15:45 -0700
Message-ID: <87ha4iesu6.fsf@x220.int.ebiederm.org>
References: <537B8AFA.4080303@elastichosts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <537B8AFA.4080303-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org> (Alin Dobre's message of
	"Tue, 20 May 2014 18:03:54 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org> writes:

> Hello,
>
> We are using 9p to run containers on top of remote filesystems, and it
> works correctly using the 3.13.11 kernel. However, there were a bunch of
> updates in the fs/9p area in 3.14 which seem to have broken the
> namespaces support for containers.

That sounds very weird.  The filesystem used should be orthogonal.

> A simple description of how we run the container over 9p is:
> - on the remote source host we run diod as 9p server
> - on the local host we mount the filesystem in /some/path
> - also locally, we run
>   contain /some/path /bin/bash
>
> In 3.14 (3.14.4 to be exact), the contain command can no longer mount
> the dev filesystem via mount("tmpfs", "dev", "tmpfs", 0, "mode=0755")
> after unsharing IPC, NS, USER, UTS and NET, but before unsharing PID.
> The above call returns an EPERM. You can look at the very simple code in
> contain.c and mount.c at [1].
>
> This call used to work fine in 3.13. I haven't tried to bisect and find
> out the exact patch that introduces the problem, but it's one of "git
> log --oneline b26d4cd.. fs/9p".

That is weird.

There has been a bunch of work to keep from abusing the ability to
mount, that added some additional constraints.

For sys and proc those constraints pretty much mean other versions of
those filesystems need to be mounted somewhere or you are not allowd to
mount a fresh copy.

I can't think of any additional rules for tmpfs off of the top of my
head.

I can't imagine off the top of my head how 9p or any specific filesystem
would be involved.

> I can provide you with any additional information that might be
> needed.

If you are building your own kernels and this is easily reproducible
it may make sense to instrument up the mount call with printks can see
where the failure is coming from.

Unless it is a basic 9p bug where directories don't appear as
directories in some cases my deep hunch is that you have found some way
to run afoul of the restrictions on mount points.

Eric
