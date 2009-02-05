From: "Dietmar Maurer" <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Subject: RE: [Devel] RE: storage considerations
Date: Thu, 5 Feb 2009 11:56:30 +0100
Message-ID: <7B7881568CF40E4388B615CD06F87B98098A1A@clara.maurer-it.com>
References: <7B7881568CF40E4388B615CD06F87B980989E9@clara.maurer-it.com>	<49887307.1080105@free.fr><20090204160518.GC2039@us.ibm.com>
	<4989C7C0.6060906@free.fr><498A1EE6.3000204@cs.columbia.edu>
	<7B7881568CF40E4388B615CD06F87B98098A12@clara.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

> And a FS independent solution would be great, so that it works on top
> of NFS too.

Replying to myself. I just noticed that this is not possible, because
NFS is a shared file system. So the only option for NFS would be a loop
mount.

- Dietmar
