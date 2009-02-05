From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: storage considerations
Date: Thu, 5 Feb 2009 09:36:38 -0600
Message-ID: <20090205153638.GD27410@us.ibm.com>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>
	<49887307.1080105@free.fr> <20090204160518.GC2039@us.ibm.com>
	<4989C7C0.6060906@free.fr> <498A1EE6.3000204@cs.columbia.edu>
	<7B7881568CF40E4388B615CD06F87B98098A12@clara.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7B7881568CF40E4388B615CD06F87B98098A12-cHQ43lMKbBKenyD9vqZGNUEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dietmar Maurer (dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org):
> > >>> Dietmar Maurer wrote:
> > >>>
> > >>>> Hi Daniel,
> > >>>>
> > >>>> I think we should have several options for the root storage:
> > >>>>
> > >>>> 1.) simply use the host filesystem (like Openvz)
> > >>>>
> > >>>> 	- special quota support is needed (simfs?)
> > >>>>
> > >>>> 	- quota support depends on ext3 fs, so this only works for
> > >>>> 	  local attached storage (does not work on NFS)
> > >>>>
> > >>>> 	- LVM snapshots are slow, because the snapshot includes all
> > >>>> container
> > >>>> 	  on that filesystem.
> > >>>>
> > >> I'm looking forward to the btrfs, tux3, and nilfs snapshotting
> > >> capabilities.
> > >>
> > > Interesting, especially the nilfs.
> > > The COW file systems is missing in the linux kernel. Do you think
> the
> > > btrfs has a chance to go to mainline ?
> > 
> > We've been using NILFS (v1) for 2 years already with Zap, and it works
> > quite well. We had to make slight (trivial) changes to be able to
> > control it nicely for c/r purposes.
> 
> NILFS, BTRFS, ... maybe provide solution for snapshots, but quota
> support
> is still missing (we need quotas on subdirectories)?

Haven't thought it through 100%, but does it not suffice to be able
to specify quotas per user-namespace?  It won't help with NFS...

> And a FS independent solution would be great, so that it works on top of
> NFS too. 
> 
> So UnionFS looks good, but it does not provide real snapshots (using 
> base + incremental change looks clumsy for our purpose). I am also not
> sure
> if quota works on UnionFS?
> 
> - Dietmar
