From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] cr_tests: futex: pu: Fix potential livelock
Date: Wed, 14 Apr 2010 09:58:40 -0500
Message-ID: <20100414145840.GA11741@us.ibm.com>
References: <2925834e94ea965d668717d0c993b6bc02697799.1271197507.git.matthltc@us.ibm.com>
	<4b62b2004556809368f788e9baaf39c529dc3d80.1271197507.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4b62b2004556809368f788e9baaf39c529dc3d80.1271197507.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Fixup flow of release_pi_futex to truly break out of the loop during
> an error.
> 
> Also, since it's not used, remove the retries parameter from
> do_unlock_contended_futex.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  futex/pi.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/futex/pi.c b/futex/pi.c
> index 53d4c5d..a39964d 100644
> --- a/futex/pi.c
> +++ b/futex/pi.c
> @@ -330,7 +330,7 @@ again:
>  	return -1;
>  }
> 
> -int do_unlock_contended_pi_futex(int retries)
> +int do_unlock_contended_pi_futex(void)
>  {
>  	if (futex(&pi_futex->counter, FUTEX_UNLOCK_PI, 1, NULL, NULL, 0) == 0)
>  		return 0;
> @@ -400,12 +400,12 @@ void release_pi_futex(int *retries, int *retval, pid_t tid)
>  		/* Release the futex */
>  		pi_val = atomic_cmpxchg(pi_futex, tid, 0);
>  		if (pi_val != tid) {
> -		    switch (do_unlock_contended_pi_futex(*retries)) {
> +		    switch (do_unlock_contended_pi_futex(void)) {

Just fyi, my compiler didn't like this.  Replacing it with
		    switch (do_unlock_contended_pi_futex()) {

It also doesn't change the failure of robust testcase on my s390 box:

linuz11:~/cr_tests/futex # sh run.sh 
Using output dir ./cr_futex_PR5nlHC
WARNING: Priority inheritance test must be able to set at least two realtime priorities. ulimit -r indicates otherwise so skipping pi futex test(s).
Running test: plain
Test plain done, returned 0
PASS
Restart of test plain done, returned 0
PASS
Running test: robust
run.sh: line 49: kill: (3900) - No such process
run.sh: line 49: kill: (3900) - No such process

Changing the line waiting for the original testcase to
exit from
	wait ${TEST_PID}
to
        wait ${TEST_PID} || true

lets that continue and pass.

(further changing it to
	wait ${TEST_PID} || echo "wait returned $?" && true
gives me
	wait returned 1
while checking process listings before and after the wait
shows that robust is running for a few seconds, and does
die before wait returns, so I assume robust.c is in fact
exiting with error code)

Meanwhile, after ulimit -r 2 pi testcase still just hogs my
cpus :)

-serge
