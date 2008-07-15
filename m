From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Devel] [RFC PATCH 0/5] Resend -v2 - Use procfs to change a
	syscall behavior
Date: Tue, 15 Jul 2008 11:18:29 -0700
Message-ID: <m1skubdn9m.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
	<20080709221028.GA4926@martell.zuzino.mipt.ru>
	<m1tzeyd0x3.fsf@frodo.ebiederm.org>
	<20080710013915.GB8327@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080710013915.GB8327-QDJVlCTZ4KWTKS93B3g+7KFoa47nwP16@public.gmane.org> (Alexey Dobriyan's
	message of "Thu, 10 Jul 2008 05:39:15 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> This is all said in assumption that serializing kernel-internal data for
> checkpoint/restart to userspace is acceptable for mainline.
> I don't think it is.

Just a quick comment here.  We mentioned checkpoint/restart is where
we were going last kernel summit, and no one was opposed.

So while I expect technical objects if we are not careful, I believe
a well chosen checkpoint/restart framework has every chance of being
merged into mainline.

Eric
