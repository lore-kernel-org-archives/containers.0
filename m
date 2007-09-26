From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Playing with namespaces and bloat-o-meeter
Date: Wed, 26 Sep 2007 17:20:06 +0400
Message-ID: <46FA5C86.90201@openvz.org>
References: <46FA528C.3000208@openvz.org>
	<20070926131349.GA20637@sergelap.austin.ibm.com>
	<46FA5BF3.4030505@fr.ibm.com> <46FA5C5C.2070906@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FA5C5C.2070906-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Cedric Le Goater wrote:
>> Serge E. Hallyn wrote:
>>> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>>>> Hi, guys!
>>>>
>>>> I've noticed that compiling out all the core related to
>>>> cloning and cleaning the new namespace saves us more than
>>>> a Kbyte (!) from the vmlinux.
>>>>
>>>> add/remove: 19/0 grow/shrink: 6/6 up/down: 1532/-336 (1196)
>>>> function                                     old     new   delta
>>>> copy_user_ns                                   -     181    +181
>>>> copy_ipcs                                      -     149    +149
>>>> copy_utsname                                   -     120    +120
>>>> shm_exit_ns                                    -     106    +106
>>>> sem_exit_ns                                    -     106    +106
>>>> msg_exit_ns                                    -     106    +106
>>>> freeary                                        -     100    +100
>>>> release_uids                                   -      95     +95
>>>> freeque                                        -      92     +92
>>>> free_nsproxy                                  48      99     +51
>>>> __sem_init_ns                                  -      45     +45
>>>> shm_init_ns                                    -      42     +42
>>>> sem_init_ns                                    -      42     +42
>>>> msg_init_ns                                    -      42     +42
>>>> __shm_init_ns                                  -      38     +38
>>>> create_new_namespaces                        300     335     +35
>>>> __msg_init_ns                                  -      31     +31
>>>> sysvipc_proc_release                           5      35     +30
>>>> free_ipc_ns                                    -      30     +30
>>>> do_shm_rmid                                    -      29     +29
>>>> shm_release                                   18      39     +21
>>>> free_user_ns                                   -      16     +16
>>>> sysvipc_proc_open                            100     111     +11
>>>> do_shmat                                     778     787      +9
>>>> free_uts_ns                                    -       5      +5
>>>> sys_shmctl                                  1934    1907     -27
>>>> msg_init                                      82      47     -35
>>>> shm_init                                      92      47     -45
>>>> sem_init                                      99      44     -55
>>>> sys_msgctl                                  1394    1311     -83
>>>> sys_semctl                                  2123    2032     -91
>>>>
>>>> Since there already were some questions like "do I need it
>>>> on my cellphone?" in reply to pid namespaces patches and 
>>>> so on, why don't we make ALL the namespaces cloning code 
>>>> under the config option to make those people happy?
>>>>
>>>> Here's the proposed patch.
>>> How about a single config variable for all namespaces?
>> yes good idea.
> 
> 
> oops, that done already in the patch : CONFIG_NAMESPACES

So... Acked-by: Serge E. Hallyn and Cedric Le Goater ? :)

> thanks :)
> 
> C.
> 
> 
