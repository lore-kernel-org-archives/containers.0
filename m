From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Regression wrt mounting /proc in user namespace in 3.13
Date: Tue, 26 Nov 2013 18:10:43 +0000
Message-ID: <20131126181043.GA25492@mail.hallyn.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k3g5gnuv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> >> Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> >> > On 11/18/2013 11:19 AM, Serge E. Hallyn wrote:
> >> > > Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> >> > >> Low on power and no charger, but a quick test printing out if a mount is
> >> > >> !S_ISDIR or has nlink !=2 in fs_fully_visible() gives me:
> >> > >>
> >> > >> [   92.939650] nlink is 1 for ino 8733 (0:3)
> >> > >>
> >> > >> (that's major 0 minor 3)
> >> > > 
> >> > > Ok, so that is for binfmt_misc on /proc/sys/fs/binfmt_misc.  The
> >> > > underlying directory is empty, and nlink is showing up as 1.
> >> > >  
> >> > > Can we just get the nlink check changed to check for < 3 instead
> >> > > of ==2 ?
> >> > > 
> >> > 
> >> > I already reported this problem to Eric,hi is working on fix this problem.
> >> > 
> >> > nlink is not the right thing to check if a directory is null. since
> >> > in all of filesystems, parent dir's nlink is increase only when we
> >> > create sub-dir.
> >> 
> >> This whole thing feels very brittle.  May I also point out that simply
> >> setting perms appears to work just fine instead of overmounting.  If I
> >> chmod 700 /proc/swaps, unshare my pid and mount namespaces and remount
> >> /proc, then /proc/swaps is 700 in the new mount.  Since our concern is
> >> with a new user namespace, which will be limited to world perms, this
> >> should suffice and allow us to skip all this nonsense.
> >> 
> >> Eric?
> >> 
> >> -serge
> >
> > So yeah, I think this patch should be reverted, rather than "fixed".
> 
> I will get back to this shortly.   The trivial fix is to kill the nlink
> test or make the nlink test look for nlink <= 2.
> 
> The point of the original patch was to remove the horrible special case
> that implemented the test to see if proc was moutned, so that we could
> trivial prevent mount of proc in chroots or other legacy environments
> where root did not want proc to be mounted.
> 
> The refinement I attempted and failed was to verify that people had only
> mounted on empty proc directories.  Just to verify that nothing becomes
> possible when mounting a new copy of proc that wasn't possible before.
> 
> My test is totally for that last case is totally braindead.  Permissions
> are nice but the actual concern is setups that did silly things that are
> not namespace aware.
> 
> I am totally against reverting the cleanup.  But I have no problem
> killing the nlink test.  Because we did not have protection against
> overmounted directories earlier.

Ok, I do need this fixed - shall I send a patch of have you already tested
a version on  your end?

thanks,
-serge
