From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [GIT PULL] binfmt_misc updates for 4.7+ merge window
Date: Thu, 28 Jul 2016 07:07:30 -0400
Message-ID: <1469704050.4197.4.camel__39478.0779294253$1469704068$gmane$org@HansenPartnership.com>
References: <1469673106.3565.9.camel@HansenPartnership.com>
	<1469674670.3998.18.camel@perches.com>
	<CA+55aFzK_kNZBNU+Eq+VuuGttOTMP3xK1F9Lsxcff-wkzaNkyg@mail.gmail.com>
	<1469676065.3998.19.camel@perches.com>
	<CA+55aFz3+37s7eQ55kGbEEoGhMtvkAwYQ3szOSVrg3MKA+iWrg@mail.gmail.com>
	<1469676632.3998.27.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1469676632.3998.27.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2016-07-27 at 20:30 -0700, Joe Perches wrote:
> On Wed, 2016-07-27 at 20:26 -0700, Linus Torvalds wrote:
> > On Wed, Jul 27, 2016 at 8:21 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> > wrote:
> > > 
> > > On Wed, 2016-07-27 at 20:12 -0700, Linus Torvalds wrote:
> > > > 
> > > > Did you actually try it.
> > > yes.
> > Well, in that case the script is buggy. It self-documents as having
> > "--git-fallback" on by default, and I'm not seeing anybody claiming
> > explicit maintenance of fs/binfmt_misc.c.
> > 
> > Al's match comes from a wildcard, not an exact one.
> 
> Nope, the script doesn't have a defect here.
> It's documented what the script does with wildcards.
> 
> You _could_ argue that the file pattern specified
> for VFS is inappropriate though,

If people prefer, I can add a MAINTAINERS entry ... it's just that none
of the binfmts currently has one, plus linux-fsdevel is still fingered
as the list and that's the place to send patches and bug reports
anyway.

James
