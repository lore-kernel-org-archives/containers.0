From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Requirements for CAP_SYS_ADMIN on setns() ?
Date: Fri, 7 Jun 2013 10:34:59 +0100
Message-ID: <20130607093459.GB10742@redhat.com>
References: <20130606100149.GG30217@redhat.com> <20130606134802.GA2930@ac100>
	<87txlb8atb.fsf@xmission.com>
	<20130606164428.GA4687@austin.hallyn.com>
	<87bo7j6r80.fsf@xmission.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bo7j6r80.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jun 06, 2013 at 11:15:11AM -0700, Eric W. Biederman wrote:
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > Quoting Daniel P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> >> >> Is it not sufficient to rely on the permissions on the /proc/$PID/ns/XXX
> >> >> file to control access to a namespace, and thus allow setns() without
> >> >> a CAP_SYS_ADMIN check ?
> 
> The permissions on /proc/$PID/ns/XXX are sufficient to control access
> but they are not ok to allow use.
> 
> >> >> ie setns() is basically useless unless you
> >> >> already have sufficient privileges to get a file descriptor for the
> >> >> namespace, so why does setns need an additional privilege check beyond
> >> >> that done at time of open() on the proc file.
> 
> To be very clear.
> 
> setns requires CAP_SYS_ADMIN because changing the namespaces for your
> children can result in tricking a suid root application and thus lead
> to privilege escalation.

Yep, ok I see that from the example shown earlier in the thread.

> If you run setns inside a user namespace that you control the privilege
> escalation is not possible and so setns is allowed.

What are the privilege requirements for being able to call setns() on
a user namespace FD ?


Thinking some more, if there was a setpidns(pid_t containerpid) syscall
which unconditionally joined the caller to all namespaces associated with
the target pid, then you'd not have the security risk described, right ?

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
