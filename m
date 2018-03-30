From: Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [REVIEW][PATCH 11/11] ipc/sem: Fix semctl(..., GETPID, ...)
	between pid namespaces
Date: Fri, 30 Mar 2018 13:45:57 -0700
Message-ID: <20180330204557.5cgyipyqawfte3ml__26531.618825584$1522443406$gmane$org@linux-n805>
References: <87vadmobdw.fsf_-_@xmission.com>
	<20180323191614.32489-11-ebiederm@xmission.com>
	<20180329005209.fnzr3hzvyr4oy3wi@linux-n805>
	<20180330190951.nfcdwuzp42bl2lfy@linux-n805>
	<87y3i91fxh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87y3i91fxh.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: esyr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org, jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prakash.sangappa-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nagarathnam Muthusamy <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 30 Mar 2018, Eric W. Biederman wrote:

>Davidlohr Bueso <dave-h16yJtLeMjHk1uMJSBkQmQ@public.gmane.org> writes:
>
>> I ran this on a 40-core (no ht) Westmere with two benchmarks. The first
>> is Manfred's sysvsem lockunlock[1] program which uses _processes_ to,
>> well, lock and unlock the semaphore. The options are a little
>> unconventional, to keep the "critical region small" and the lock+unlock
>> frequency high I added busy_in=busy_out=10. Similarly, to get the
>> worst case scenario and have everyone update the same semaphore, a single
>> one is used. Here are the results (pretty low stddev from run to run)
>> for doing 100,000 lock+unlock.
>>
>> - 1 proc:
>>   * vanilla
>> 	total execution time: 0.110638 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 0.120144 seconds for 100000 loops
>>
>> - 2 proc:
>>   * vanilla
>> 	total execution time: 0.379756 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 0.477778 seconds for 100000 loops
>>
>> - 4 proc:
>>   * vanilla
>> 	total execution time: 6.749710 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 4.651872 seconds for 100000 loops
>>
>> - 8 proc:
>>   * vanilla
>>        total execution time: 5.558404 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 7.143329 seconds for 100000 loops
>>
>> - 16 proc:
>>   * vanilla
>> 	total execution time: 9.016398 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 9.412055 seconds for 100000 loops
>>
>> - 32 proc:
>>   * vanilla
>> 	total execution time: 9.694451 seconds for 100000 loops
>>   * dirty
>> 	total execution time: 9.990451 seconds for 100000 loops
>>
>> - 64 proc:
>>   * vanilla
>> 	total execution time: 9.844984 seconds for 100032 loops
>>   * dirty
>> 	total execution time: 10.016464 seconds for 100032 loops
>>
>> Lower task counts show pretty massive performance hits of ~9%, ~25%
>> and ~30% for single, two and four/eight processes. As more are added
>> I guess the overhead tends to disappear as for one you have a lot
>> more locking contention going on.
>
>Can you check your notes on the 4 process case?  As I read the 4 process
>case above it is ~30% improvement.  Either that is a typo or there is the
>potential for quite a bit of noise in the test case.

Yeah, sorry that was a typo. Unlike the second benchmark I didn't have
this one automated but it's always the vanilla kernel that outperforms
the dirty.

Thanks,
Davidlohr
