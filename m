From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Tue, 2 Jul 2013 17:45:14 +0100
Message-ID: <20130702164514.GB2524@redhat.com>
References: <20130701161625.GQ15954@redhat.com>
	<51D261D3.3030002@cn.fujitsu.com> <87wqp9uz9a.fsf@xmission.com>
	<51D295C5.1080003@nod.at> <20130702092554.GD2524@redhat.com>
	<87ehbhthbl.fsf@xmission.com> <51D2A649.9030102@cn.fujitsu.com>
	<8761wsudgk.fsf@xmission.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8761wsudgk.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 02, 2013 at 09:35:39AM -0700, Eric W. Biederman wrote:
> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> 
> > On 07/02/2013 05:57 PM, Eric W. Biederman wrote:
> >> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >>> On Tue, Jul 02, 2013 at 10:56:37AM +0200, Richard Weinberger wrote:
> >>>> Am 02.07.2013 10:44, schrieb Eric W. Biederman:
> >>>>> Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:
> >>>>>
> >>>>>> On 07/02/2013 12:16 AM, Daniel P. Berrange wrote:
> >>>>>>> I'm struggling debugging a strange problem with interaction between user
> >>>>>>> namespaces, cap_set and ownership of files in /proc/1/
> >>>>>>>
> >>>>>>
> >>>>>> This problem is occured after we call setuid/gid.
> >>>>>>
> >>>>>> for example, a task whose pid is 1234 calls
> >>>>>> setregid(10,10);
> >>>>>> setreuid(10,10);
> >>>
> >>> If seems to get reset to the right values (0:0) when we execve()
> >>> the init binary though.  This doesn't happen if we have invoked
> >>> the capset() syscall in between the setregid & the execve() calls.
> >> 
> >> Yes, execve() should reset the dumpable state.
> >> 
> >> I took a quick look and I don't see a way around set_dumpable calls in
> >> setup_new_exec.  Why the process remains undumpable after exec is worth
> >> investigating.  That logic should not be user namespace specific
> >> however.
> >> 
> >
> > I think it's the install_exec_creds, it calls commit_creds to set process undumpable
> >
> >         /* dumpability changes */
> >         if (!uid_eq(old->euid, new->euid) ||
> >             !gid_eq(old->egid, new->egid) ||
> >             !uid_eq(old->fsuid, new->fsuid) ||
> >             !gid_eq(old->fsgid, new->fsgid) ||
> >             !cred_cap_issubset(old, new)) {
> >                 if (task->mm)
> >                         set_dumpable(task->mm, suid_dumpable);
> >                 task->pdeath_signal = 0;
> >                 smp_wmb();
> >         }
> 
> That looks like it could do it.  Especially if exec is increasing your
> capabilities.

Ah, yes, that would explain it. My demo is removing the SYS_MODULE
capability, and then exec'ing the shell binary. Since we are uid==0,
and prctl(PR_CAPBSET_DROP) is not available inside the user namespace,
the rules for capabilities vs execve() call will cause the shell
binary to regain SYS_MODULE capability bit.

So the problem I'm seeing in libvirt is all a result of the fact
that we can't use PR_CAPBSET_DROP inside the user namespace. Given
that there's no point trying to drop any capabilities inside the
user namespace.

The only slight problem here is that we want to drop CAP_MKNOD so
that systemd can detect that it shouldn't attempt to run any units
which would rely on mknod.

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
