From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v2] core_pattern: set core helpers root and namespace to
	crashing process
Date: Fri, 14 Dec 2012 19:50:44 -0500
Message-ID: <20121215005044.GB10508@neilslaptop.think-freely.org>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
	<1355519048-28473-1-git-send-email-nhorman@tuxdriver.com>
	<87d2ycut5l.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87d2ycut5l.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 14, 2012 at 03:10:30PM -0800, Eric W. Biederman wrote:
> Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> writes:
> 
> > As its currently implemented, redirection of core dumps to a pipe reader should
> > be executed such that the reader runs in the namespace of the crashing process,
> > and it currently does not. This is the only sane way to deal with namespaces
> > properly it seems to me, and this patch implements that functionality.
> 
> I actually rather strongly disagree.
> 
> While we have a global core dump pattern core dumps to a a pipe reader
> should be executed such that the reader runs in the namespace of the
> process that set the pattern.  We can easily restrict that to the
> initial namespaces to make the implementation simpler.
> 
> If you want to play namespace games you can implement all of those in
> user space once my tree merges for v3.8.
> 
> I am really not a fan of the trigger process being able to control the
> environment of a privileged process.  It makes writing the privileged
> process much trickier.
> 
Why?  What specific problem do you see with allowing a privlidged process to
execute within a specific namespace, that doesn't also exist with having the
pipe reader execute in the init namespace?  Note I'm not saying that a poorly
constructed pipe reader application doesn't have security problems if it doesn't
validate the environment that its running in, but thats something that the pipe
reader needs to be sure about.

Note also, that if the token in core_pattern is set such that the core_pattern
is namespace/root relative, that container needs to install the application
relative its root as well (e.g. positive action still needs to be taken on the
part of the container admin to make this work).  For example, if you set
core_pattern="||/usr/bin/foo"
Then a process running in a chroot based at /sub/root/ still needs to install a
file /sub/root/usr/bin/foo, or the core dump will fail.  So its not like a
container can just have a core reader execute without first making an
administrative decision to do so.

Neil
