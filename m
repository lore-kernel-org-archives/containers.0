From: "Dietmar Maurer" <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Subject: RE: storage considerations
Date: Thu, 5 Feb 2009 08:08:41 +0100
Message-ID: <7B7881568CF40E4388B615CD06F87B98098A13@clara.maurer-it.com>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>
	<49887307.1080105@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49887307.1080105-GANU6spQydw@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

> > 2.) loop mounting an image (dm-loop)
> >
> > 	- quota works
> >
> > 	- works on any filesystem (even NFS)
> >
> > 	- don't know how to make snapshots?
> >
> Perhaps we can use the future union mount or unionfs in order to make
> incremental snapshot ?

Or maybe it is possible to make an LVM snapshot of a dm-loop device? (I
already
asked that on the Linux-lvm mailing list but got no answer).

- Dietmar
