From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix misquoting in simple/runtests.sh
Date: Tue, 4 Aug 2009 16:46:58 -0700
Message-ID: <20090804234658.GD18261@count0.beaverton.ibm.com>
References: <1249429388-12900-3-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249429388-12900-3-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Also for cr_tests.

On Tue, Aug 04, 2009 at 04:43:10PM -0700, Matt Helsley wrote:
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  simple/runtests.sh |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>  mode change 100644 => 100755 simple/runtests.sh
> 
> diff --git a/simple/runtests.sh b/simple/runtests.sh
> old mode 100644
> new mode 100755
> index 99bc133..860a5ee
> --- a/simple/runtests.sh
> +++ b/simple/runtests.sh
> @@ -22,7 +22,7 @@ if [ ! $v -gt 0 ]; then
>  fi
> 
>  $RSTR < out
> -v=`grep ret /tmp/cr-test.out | awk -F=  '{ print $2 '}`
> +v=`grep ret /tmp/cr-test.out | awk -F=  '{ print $2 }'`
>  if [ "x$v" == "x" ]; then
>  	echo "FAIL - rstrt return value was not in /tmp/cr-test.out"
>  	exit 4
> -- 
> 1.5.6.3
> 
