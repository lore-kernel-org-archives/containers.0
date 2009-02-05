From: "Dietmar Maurer" <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Subject: RE: storage considerations
Date: Thu, 5 Feb 2009 16:45:55 +0100
Message-ID: <7B7881568CF40E4388B615CD06F87B98098A22@clara.maurer-it.com>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>
	<49887307.1080105@free.fr> <20090204160518.GC2039@us.ibm.com>
	<4989C7C0.6060906@free.fr> <498A1EE6.3000204@cs.columbia.edu>
	<7B7881568CF40E4388B615CD06F87B98098A12@clara.maurer-it.com>
	<20090205153638.GD27410@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20090205153638.GD27410-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

> > NILFS, BTRFS, ... maybe provide solution for snapshots, but quota
> > support
> > is still missing (we need quotas on subdirectories)?
> 
> Haven't thought it through 100%, but does it not suffice to be able
> to specify quotas per user-namespace?  It won't help with NFS...

I was not aware that this is possible. How do I enable per
user-namespace quotas?

- Dietmar
