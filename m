From: Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/9] I/O bandwidth controller and BIO tracking
Date: Mon, 14 Sep 2009 07:11:20 -0700
Message-ID: <1252937480.28368.221.camel__48656.3277700499$1252937498$gmane$org@desktop>
References: <20090914.212805.193688121.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090914.212805.193688121.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-09-14 at 21:28 +0900, Ryo Tsuruta wrote:

> The list of the patches:
>   [PATCH 1/9] I/O bandwidth controller and BIO tracking
>   [PATCH 2/9] dm-ioband-1.13.0: All-in-one patch
>   [PATCH 3/9] blkio-cgroup-v12: The new page_cgroup framework
>   [PATCH 4/9] blkio-cgroup-v12: Refactoring io-context initialization
>   [PATCH 5/9] blkio-cgroup-v12: The body of blkio-cgroup
>   [PATCH 6/9] blkio-cgroup-v12: Page tracking hooks
>   [PATCH 7/9] blkio-cgroup-v12: The document of blkio-cgroup
>   [PATCH 8/9] blkio-cgroup-v12: Add a cgroup support to dm-ioband
>   [PATCH 9/9] blkio-cgroup-v12: The document of a cgroup support for dm-ioband


Patches 5, 8, and 9 all have checkpatch errors (2 does also but it
involves tracing, so Steven may not let you fix them). 

Could you correct those errors before this get included ?

Daniel
