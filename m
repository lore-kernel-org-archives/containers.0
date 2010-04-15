From: Shivaram Venkataraman <shivaram.venkataraman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Linux Container Patches for 2.6.24
Date: Thu, 15 Apr 2010 18:08:35 -0500
Message-ID: <z2v9bca87c91004151608s3fc09c9bmb690948e32123374@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Will Dietz <w@wdtz.org>
List-Id: containers.vger.kernel.org

I am working on a project that is looking at using Linux container
support for embedded devices. From the man page, I found that
container support is present in versions >=2.6.27. However we are
working with a 2.6.24 kernel (which we can't upgrade) and it looks
like other than network and procfs support, other changes were made
prior to 2.6.24.
The patch set for the older kernels are no longer present in
http://lxc.sourceforge.net/patches and I'd like to know if there is
any other way I could obtain the patches.

Furthermore could anybody let me know how complex it would be to
backport the network and procfs changes to 2.6.24 ?

Thanks in advance for your help
Shivaram
