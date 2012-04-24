From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 30/43] userns: Fail exec for suid and sgid binaries with
	ids outside our user namespace.
Date: Tue, 24 Apr 2012 10:10:40 -0500
Message-ID: <20120424151040.GA2979@ubuntu>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-30-git-send-email-ebiederm@xmission.com>
	<20120418190927.GK5186@mail.hallyn.com>
	<m1ehrdrhgr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1ehrdrhgr.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> 
> >
> > Oh, perhaps this is the right place in the thread to discuss the issue of
> > what to do with file capabilities?  I'm ok waiting until the next iteration
> > to even discuss it, so long as we start by refusing setting of fcaps by
> > any task not in init_user_ns.
> 
> For now we do refuse all callers in the init_user_ns because that path
> is protected by a capable and not an ns_capable call.
> 
> And as a general policy I have pushed all of the changes from capable to
> ns_capable out till after we get these other user namespace bits so we
> can get the patches reviewed so hopefully don't enable something that is
> not safe.
> 
> Let's just note here that when we ever get a filesystem mounted in
> something other than the init_user_ns or otherwise allow file
> capabilities that do not belong to the init_user_ns we need to an
> additional exec check to avoid a security issue for processes in the
> init_user_ns using those credentials.
> 
> The other direction the init_user_ns setting file caps on a file and use
> using them in a child namespace seems safe, and practical because of the
> way we handle capabilities.  Aka if you have a capability in an outer
> user namespace you also have it in a child user namespace.  Which means
> a file cap exec today will give you just the capabilities in the child
> user namespace.
> 
> Something else to think about when we reach filesystems mounted in
> different user namespaces (aka unprivileged mounts) are security
> labels on files in different user namespaces.  Not any kind of immediate
> concern but something we may have to handle eventually.

An interesting concern to discuss at the security mini-summit (or just
at the UDS session).

-serge
