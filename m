From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/5] userns: Don't read extents twice in m_start
Date: Wed, 01 Nov 2017 06:08:35 -0500
Message-ID: <87a806ntn0.fsf__14180.6225911298$1509534540$gmane$org@xmission.com>
References: <20171024220441.10235-1-christian.brauner@ubuntu.com>
	<20171024220441.10235-2-christian.brauner@ubuntu.com>
	<871sliubhj.fsf_-_@xmission.com> <87k1zaswu6.fsf_-_@xmission.com>
	<143adb61-fb8e-fc1b-396b-b18836e68766@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <143adb61-fb8e-fc1b-396b-b18836e68766-IBi9RG/b67k@public.gmane.org> (Nikolay
	Borisov's message of "Wed, 1 Nov 2017 10:31:25 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org>
Cc: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, tycho-E0fblnxP3wo@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <nborisov-IBi9RG/b67k@public.gmane.org> writes:

> On  1.11.2017 01:48, Eric W. Biederman wrote:
>> 
>> This is important so reading /proc/<pid>/{uid_map,gid_map,projid_map} while
>> the map is being written does not do strange things.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  kernel/user_namespace.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>> 
>> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
>> index 563a2981d7c7..4f7e357ac1e2 100644
>> --- a/kernel/user_namespace.c
>> +++ b/kernel/user_namespace.c
>> @@ -683,11 +683,13 @@ static void *m_start(struct seq_file *seq, loff_t *ppos,
>>  		     struct uid_gid_map *map)
>>  {
>>  	loff_t pos = *ppos;
>> +	unsigned extents = map->nr_extents;
>> +	smp_rmb();
>
> Barriers need to be paired to work correctly as well as have explicit
> comments describing the pairing as per kernel coding style. Checkpatch
> will actually produce warning for that particular memory barrier.

So please look at the code and read the comment.  The fact the barrier
was not in m_start earlier is strictly speaking a bug.

In practice except for a very narrow window when this data is changing
the one time it can, this code does not matter at all.

As for checkpatch I have sympathy for it, checkpatch has a hard job,
but I won't listen to checkpatch when it is wrong.

If you have additional cleanups you would like to make in this area
please send patches.

Eric

>>  
>> -	if (pos >= map->nr_extents)
>> +	if (pos >= extents)
>>  		return NULL;
>>  
>> -	if (map->nr_extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
>> +	if (extents <= UID_GID_MAP_MAX_BASE_EXTENTS)
>>  		return &map->extent[pos];
>>  
>>  	return &map->forward[pos];
>> 
