From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: Obtaining the latest kernel to test out the latest on the
	containers
Date: Mon, 30 Jun 2008 16:44:07 -0700
Message-ID: <20080630234407.GA15202@us.ibm.com>
References: <c7704c490806241353s53493204g5db4ad45e77d238c@mail.gmail.com>
	<20080624222618.GA16783@us.ibm.com>
	<c7704c490806241652wb8862b2k9643fd902f4b9505@mail.gmail.com>
	<c7704c490806241654t56ccfe74k5711dfd81779ae1f@mail.gmail.com>
	<c7704c490806301609n3437aa7dlbd191200ce4205ec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c7704c490806301609n3437aa7dlbd191200ce4205ec-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Mukesh G [mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] wrote:
|       I am having issues applying the patch set (2.6.26-rc5-mm3-lxc1) where
| the patch fails for many files.
| 
| Here are the steps followed
| 1) Successfully installed 2.6.25-rc5 vanilla
| 2) Successfully applied patch 2.6.26-rc5-mm3 patch
| 3) Errors applying patch set 2.6.26-rc5-mm3-lxc1-broken-out
| 
| # patch -p1 </tmp/2.6.26-rc5-mm3-lxc1-broken-out.tar

Are you trying to apply the .tar file ? 

Can you unzip and try with the following file instead

http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc5-mm3-lxc1/2.6.26-rc5-mm3-lxc1.patch.gz
