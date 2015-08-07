From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 1/6] mnt: Track which mounts use a dentry as root.
Date: Fri, 07 Aug 2015 10:43:25 -0500
Message-ID: <871tffkste.fsf__15418.5291532942$1438962638$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87vbcw9i8g.fsf_-_@x220.int.ebiederm.org> <55C48C94.6050804@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <55C48C94.6050804-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Fri, 7
	Aug 2015 13:46:44 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index 2b8aa15fd6df..2ce987af9afa 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -31,6 +31,8 @@ static unsigned int m_hash_mask __read_mostly;
>>  static unsigned int m_hash_shift __read_mostly;
>>  static unsigned int mp_hash_mask __read_mostly;
>>  static unsigned int mp_hash_shift __read_mostly;
>> +static unsigned int mr_hash_mask __read_mostly;
>> +static unsigned int mr_hash_shift __read_mostly;
>>  
>>  static __initdata unsigned long mhash_entries;
>>  static int __init set_mhash_entries(char *str)
>> @@ -52,6 +54,16 @@ static int __init set_mphash_entries(char *str)
>>  }
>>  __setup("mphash_entries=", set_mphash_entries);
>>  
>> +static __initdata unsigned long mrhash_entries;
>> +static int __init set_mrhash_entries(char *str)
>> +{
>> +	if (!str)
>> +		return 0;
>> +	mrhash_entries = simple_strtoul(str, &str, 0);
>
> Nit: Any particular reason for using simple_* rather than kstrto* family
> of functions?

That is what set_mhash_entries, and set_mphash_entries do, and I
maintained the existing style in the code.

It does look like a followup change to add error handling in the
pathological cases might be worthwhile.

Although it would probably be even better to convert these hash tables
into rcu resizeable hash tables that can automatically grow to the size
needed.

Eric
