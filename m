From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Wed, 5 Sep 2012 13:10:59 +0100
Message-ID: <20120905121058.GB21383@redhat.com>
References: <20120830225002.GA9226@redhat.com> <87bohrhqai.fsf@xmission.com>
	<5044629C.3030909@parallels.com> <87r4qi6g6k.fsf@xmission.com>
	<20120904144428.GB14093@amd1> <50461421.7030305@parallels.com>
	<20120904152526.GB19564@amd1> <50461EBB.2050501@parallels.com>
	<20120904171818.GA5334@mail.hallyn.com>
	<87vcft1shu.fsf@xmission.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vcft1shu.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Sep 04, 2012 at 12:46:05PM -0700, Eric W. Biederman wrote:
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >> Not all files provided by the kernel are "per-kernel". /proc/self is
> >> full of per-namespace stuff.
> >> 
> >> >> The way I see it, every file we need to setup from the outside is a
> >> >> hassle. Among many other things, it is just asking for duplication of
> >> >> efforts among multiple userspaces.
> >> >>
> >> >> netns does this for its proc files. The only reason we don't do it for
> >> >> cgroups-driven file, is that the semantics is very ill-defined. For this
> >> >> file, it doesn't seem to be the case.
> >> > 
> >> > But it is the case.  How do you intend to have the kernel decide what
> >> > value to put in there for a process in a container, or in a chroot?
> >> > 
> >> 
> >> one value per pidns.
> >
> > ok.  (So should it be called /proc/pidns_uuid?  Well, whatever.  No
> > objection from me - thanks.)
> 
> /proc/sys/kernel/boot_id.
> 
> Someday we will get the plumbing right in the kernel so that can be
> /proc/sys -> /proc/self/sys and /proc/self/sys/kernel/boot_id
> 
> The origin of boot_id was so that emacs could implement distributed
> locking in userspace by creating a symlink from .#filename to 
> user-WI0L6dQK/Vr7saj2s7cPmQ@public.gmane.org:boot_id.
> 
> Ultimately emacs opted to just stat /var/run/random-seed or to grovel
> through utmp or wtmp to find the last boot record.
> 
> Of course /var/run/random-seed is now named something like
> /var/lib/urandom/random-seed as distributions continue their relentless
> pursuit to break userspace.
> 
> But ultimately boot_id was defined as something you can use to detect
> stale pids and stale lockfiles.  Since the original definition was
> a uuid to detect stale pids, that seems a reasonable justification
> for keeping it in the pid_namespace.  Boot_id isn't the best name in
> that case but shrug.

Ok, so reading through this thread, my understanding is that any patch
for this needs to work as follows:

 - Associate '/proc/sys/kernel/random/boot_id' with the pid namespace

 - Allow boot_id to be written to, only if it has not yet been
   read in the current pid namespace. (for migration use case)

 - Lazy generate a UUID for boot_id on first read in the current pid
   namespace, only if it has not previously been written to.

 - Add file to Documentation/ explaining the use case for the boot_id
   file and its semantics wrt to namespaces.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
