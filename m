From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: cpu shielding.
Date: Tue, 7 Feb 2012 14:35:39 +0400
Message-ID: <4F30FE7B.4040305@parallels.com>
References: <1328536234.32188.49.camel@foo> <20120207021527.GA17937@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120207021527.GA17937@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: atp <Andrew.Phillips-xheW4WVAX9Y@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/07/2012 06:15 AM, Serge Hallyn wrote:
> Quoting atp (Andrew.Phillips-xheW4WVAX9Y@public.gmane.org):
>> Hello,
>>
>>    Apologies if I'm about to ask a frequently asked question - I did
>> check back over the last couple of months.
>>
>>    Is anyone working on cpu shielding for processes inside a cpu cgroup?
>>
>>    We would like to run Java in containers, and unfortunately it likes to
>> know how many processors there are in the system - to initialise thread
>> pools and such like.
>>
>>    I was thinking along these lines;
>>
>> --- fs/proc/stat.c.orig	2010-05-21 11:32:32.941258466 +0000
>> +++ fs/proc/stat.c	2010-05-21 11:40:47.681259133 +0000
>> @@ -39,7 +39,9 @@
>>   	getboottime(&boottime);
>>   	jif = boottime.tv_sec;
>>
>> -	for_each_possible_cpu(i) {
>> +//	for_each_possible_cpu(i) {
>> +//	// refer to the visible cpus.
>> +	for_each_cpu_and(i,cpu_possible_mask,(&current->cpus_allowed)) {
>>   		user = cputime64_add(user, kstat_cpu(i).cpustat.user);
>>   		nice = cputime64_add(nice, kstat_cpu(i).cpustat.nice);
>>   		system = cputime64_add(system, kstat_cpu(i).cpustat.system);
>> @@ -78,7 +80,10 @@
>>   		(unsigned long long)cputime64_to_clock_t(steal),
>>   		(unsigned long long)cputime64_to_clock_t(guest),
>>   		(unsigned long long)cputime64_to_clock_t(guest_nice));
>> -	for_each_online_cpu(i) {
>> +
>> +//	for_each_online_cpu(i) {
>> +//	// cgroup.
>> +	for_each_cpu_and(i,cpu_online_mask,(&current->cpus_allowed)) {
>>
>>   		/* Copy values here to work around gcc-2.95.3, gcc-2.96 */
>>   		user = kstat_cpu(i).cpustat.user;
>>
>>    I'm sure that there are nicer ways of doing this, but Serge Hallyn
>> suggested a while ago that I post here. Even though it says 2010, the
>> patch above looks like it will go against 3.2.4 ok.
>>
>>    Thanks,
>>       Andy
>
> I'm afraid I haven't been following recent upstream discussions on
> this, but there are other people who want proc to show cgroup-limited
> information.  See for instance http://lwn.net/Articles/460310/ .  Glauber
> has also brought this up since then.  I'd recommend pinging him.
>
> I'm all for /proc showing cgroup-filtered information, unconditionally.
>

Hi.

I have a patchset pending for review that deals with some part of that. 
(http://lwn.net/Articles/479624/)

The way I see it, there are two parts of the problem: One of them is 
keeping all those information consistently in the cgroup. I don't really 
like your patch, btw, because it takes the process as the main entity, 
and that is not really proc's idea. I'd go to the route of trying to 
devise a cpumask from the cgroup, and then expose this. That said, I 
believe anything in this area is far from a consensus.

Another problem is how to effectively display such data, after you 
gathered it. I am not essentially opposed to unconditionally displaying 
cgroup-filtered data as well, and I've sent a couple of patches trying 
to achieve that. But there are some problems with this approach that are 
preventing consensus now.
