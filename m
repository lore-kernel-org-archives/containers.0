From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Wed, 01 Oct 2008 14:38:44 +0200
Message-ID: <48E36F54.1090809@fr.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>	<20080912175308.GI17350@us.ibm.com>	<1222286127.15523.66.camel@nimitz>	<20080926212115.GD31505@us.ibm.com>	<1222464662.25451.23.camel@nimitz>	<20080927004727.GA2161@us.ibm.com>
	<48E0DF71.2070007@fr.ibm.com> <20080930151325.GA26713@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080930151325.GA26713-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

>> +static int compare_sb_single_ns(struct super_block *sb, void *data)
>> +{
>> +	return sb->s_fs_info == data;
>> +}
>> +
>> +static int set_sb_single_ns(struct super_block *sb, void *data)
>> +{
>> +	struct mq_namespace *mq_ns = (struct mq_namespace *) data;
>> +	int error;
>> +
>> +	sb->s_fs_info = get_mq_ns(mq_ns);
>> +	error = set_anon_super(sb, NULL);
>> +	if (error)
>> +		put_mq_ns(mq_ns);
> 
> Hmm, how come fs/proc/root.c doesn't do a put_pid_ns if set_anon_super()
> failed?  Does it need to do that, or is there some part of the error
> path cleanup at a higher level that would cause that to happen anyway
> (i.e. kill_sb ends up being called anyway)?

the kill_sb ops is only called on an active super_block which can not 
happen if sget() fails. This means that proc_set_super() fails to decrement 
the refcount on the newly created pid namespace if set_anon_super() fails.
That was spotted by Nadia on the mq namespace.

I'll add the following patch to the -lxc patchset to see how it behaves 
under test.

Thanks,

C.

commit f5ab821d6e4ca95bd19d79f7e5ba58a6fb63f6b0
Author: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Date:   Wed Oct 1 14:34:57 2008 +0200

    proc_set_super() fails to decrement the refcount on the pid namespace
    if set_anon_super() fails.
    
    Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 9511753..55227d4 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -30,10 +30,14 @@ static int proc_test_super(struct super_block *sb, void *data)
 static int proc_set_super(struct super_block *sb, void *data)
 {
        struct pid_namespace *ns;
+       int error;
 
        ns = (struct pid_namespace *)data;
        sb->s_fs_info = get_pid_ns(ns);
-       return set_anon_super(sb, NULL);
+       error = set_anon_super(sb, NULL);
+       if (error)
+               put_pid_ns(ns);
+       return error;
 }
 
 static int proc_get_sb(struct file_system_type *fs_type,
