From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Regression wrt mounting /proc in user namespace in 3.13
Date: Mon, 18 Nov 2013 14:08:30 +0000
Message-ID: <20131118140830.GA22075@mail.hallyn.com>
References: <20131115164123.GN28794@redhat.com>
	<20131116164840.GA4441@mail.hallyn.com>
	<20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52899D09.5080202-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> On 11/18/2013 11:19 AM, Serge E. Hallyn wrote:
> > Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> >> Low on power and no charger, but a quick test printing out if a mount is
> >> !S_ISDIR or has nlink !=2 in fs_fully_visible() gives me:
> >>
> >> [   92.939650] nlink is 1 for ino 8733 (0:3)
> >>
> >> (that's major 0 minor 3)
> > 
> > Ok, so that is for binfmt_misc on /proc/sys/fs/binfmt_misc.  The
> > underlying directory is empty, and nlink is showing up as 1.
> >  
> > Can we just get the nlink check changed to check for < 3 instead
> > of ==2 ?
> > 
> 
> I already reported this problem to Eric,hi is working on fix this problem.
> 
> nlink is not the right thing to check if a directory is null. since
> in all of filesystems, parent dir's nlink is increase only when we
> create sub-dir.

This whole thing feels very brittle.  May I also point out that simply
setting perms appears to work just fine instead of overmounting.  If I
chmod 700 /proc/swaps, unshare my pid and mount namespaces and remount
/proc, then /proc/swaps is 700 in the new mount.  Since our concern is
with a new user namespace, which will be limited to world perms, this
should suffice and allow us to skip all this nonsense.

Eric?

-serge
