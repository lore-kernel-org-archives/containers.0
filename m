From: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ISSUE] mm: Add a user_ns owner to mm_struct and fix
	ptrace_may_access
Date: Tue, 25 Oct 2016 12:02:13 +0300
Message-ID: <20161025090213.GX1847__2387.10692287913$1477386171$gmane$org@uranus.lan>
References: <20161024105959.GQ1847@uranus.lan> <8760oh8tbp.fsf@xmission.com>
	<20161024202925.GS1847@uranus.lan>
	<CAGXu5jK4p4bbQU1Bu-p9aM1GJ+CAR-FAHZcXXRH0De_M4VQ3wA@mail.gmail.com>
	<8760oh737b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8760oh737b.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Andrey Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 24, 2016 at 06:11:04PM -0500, Eric W. Biederman wrote:
> Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:
> 
> > On Mon, Oct 24, 2016 at 1:29 PM, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> On Mon, Oct 24, 2016 at 02:01:30PM -0500, Eric W. Biederman wrote:
> >>> So I am probably going to tweak the !mm case so that instead of failing
> >>> we perform the old capable check in that case.  That seems the mot
> >>> certain way to avoid regressions.  With that said, why is exit_code
> >>> behind a ptrace_may_access permission check?
> >>
> >> Yes, this would be great! And as to @exit_code I think better ask
> >> Kees, CC'ed.
> >
> > My concern was that this was an exposure in the sense that it is
> > internal program state that isn't visible through other means (without
> > being the parent, for example). Under the ptrace check, it has an
> > equivalency that seemed correct at the time.
> >
> > As already covered, I'd agree: it looks like ce99dd5fd5f6 accidentally
> > added a dependency on task->mm where it didn't before. That section of
> > logic was entirely around dumpability, not an mm existing. It should
> > be "EPERM if mm and dumpable != SUID_DUMP_USER".
> >
> > That said, I'd also agree that ptrace against no mm is crazy (though I
> > suppose that should return EINVAL or ESRCH or something), so perhaps a
> > better access control on @exit_code is needed here.
> 
> I traced down the original logic of why we had that dumpable
> variable, and it was ancient conservative on my part when we started
> using the ptrace permission checks for proc files.
> 
> That same conservatism has resulted in the regression under
> discussion.
> 
> Given that we already have a very full set of permission checks
> separate from dumpable in ptrace_may_access I think it makes sense
> to simply ignore dumpable when there is no mm.
> AKA:
> 	mm = task->mm;
> 	if (mm &&
> 	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
> 	     !ptrace_has_cap(mm->user_ns, mode)))
> 	    return -EPERM;
> 
> Because while it has been used for other things dumpable is
> fundamentally about do you have permission to read the mm.
> So there is no real point in permission checks that protect
> the mm if the mm has gone away.
> 
> It also looks like I may need to update the check that sets
> PT_PTRACE_CAP to look at mm->user_ns as well.

Thanks a lot for informative explanations, Eric and Kees!
Eric, if you make some patch please ping me to test it.
