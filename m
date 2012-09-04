From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Tue, 4 Sep 2012 10:28:23 -0500
Message-ID: <20120904152823.GC19564@amd1>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120830225002.GA9226@redhat.com> <87bohrhqai.fsf@xmission.com>
	<5044629C.3030909@parallels.com> <87r4qi6g6k.fsf@xmission.com>
	<5045BF05.9050707@parallels.com> <878vcq5ekx.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <878vcq5ekx.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> >> The twist of course is what does a boot mean.  If we are really after
> >> machine boots than the current behavior is correct.
> >> 
> >> Looking back in the archives the desired behavior appears to be a value
> >> that can be used to see if a pid value must be stale.
> >> 
> >> As a stale pid detector boot_id is pretty lousy.  Pids can still be
> >> reused.
> >> 
> >> Still a role as a stale pid detector makes it clear which namespace
> >> boot_id should be in and how we should treat boot_id upon migration.
> >> 
> >> You can only serve as a stale pid detector if you are in the pid
> >> namespace.
> >> 
> >> So at this point patches are welcome.  Hopefully with a summary
> >> of the discussion.
> >> 
> >> Eric
> >> 
> >
> > Your discussion about boot_id being a limited solution is totally valid.
> > But it is orthogonal to the question of whether or not a container
> > should have it.
> 
> The important part is that boot_id as originally conceived is an
> identifier to be used in conjunction with pids.  Therefore boot_id is a
> proper pid_namespace component, and there are no semantic problems with
> putting it in the kernel.
> 
> > I took a look at this, and I think the kernel should be in perfect
> > position to do it.
> 
> Agreed.
> 
> > boot_id as a pid namespace id is a very well defined concept.
> 
> Agreed.
> 
> A reference to the history and the definition needs to be in the patch
> description.

Huh.  I must have glossed over that part of this thread.  If you both
agree to that, then I'm fine with it - I'll go read the history when the
new patch comes by.

thanks,
-serge
