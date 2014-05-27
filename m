From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: User namespace over 9p
Date: Tue, 27 May 2014 03:39:54 -0700
Message-ID: <87fvjvpksl.fsf@x220.int.ebiederm.org>
References: <53846804.6080408@elastichosts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53846804.6080408-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org> (Alin Dobre's message of
	"Tue, 27 May 2014 11:25:08 +0100")
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
> Continuing the struggle to run containers over the 9p filesystem I am
> now running into another issue.
>
> A simple container with user namespace mapping UID -2 (4294967294) to
> root can run a container image found in /tmp/src without any problems.
> When I export that /tmp/src path via 9p and mount it in /tmp/dst,
> running the same container over /tmp/dst fails to allow chown (and
> probably chmod) system calls to be successful. This happens because 9p
> considers that the UID which runs the system calls is actually -2, but
> it's actually 0, because the lchown system call is run inside the
> namespace, not outside it. So, 9p should consider that the UID which
> does the system call is root.

No the UID is actually -2. (-2 is a little dangerous to use because
sometimes -2 is used for the nobody user and similar special purposes).

There is some minor relaxation of the rules in the vfs to allow changing
to a uid you have mapped in your user namespace.  Which is why chown
works at all.

> Do I understand this correctly as a problem, or does it work as
> intended? If latter, do you have any insights on how to achieve running
> containers in this scenario?

If the permission check is made on the kernel with user namespaces we
can reasonablly make it work.  Otherwise we can not.  That is a danger
of using remote filesystems they can sometimes have weird arbitrary
rules you were not expected.

Eric
