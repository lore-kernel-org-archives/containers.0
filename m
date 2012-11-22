From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 01/12] userns: Support 9p interacting with multiple
	user namespaces
Date: Thu, 22 Nov 2012 03:58:17 -0800
Message-ID: <87vccxzw6e.fsf@xmission.com>
References: <50AC9CD8.8020207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50AC9CD8.8020207-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Zhao Hongjiang's message of "Wed,
	21 Nov 2012 17:20:24 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 2012/11/20 20:43, Eric W. Biederman wrote:
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
>> diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
>> index d934f04..1c750ab 100644
>> --- a/fs/9p/v9fs.c
>> +++ b/fs/9p/v9fs.c
>> @@ -161,7 +161,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
>>  				ret = r;
>>  				continue;
>>  			}
>> -			v9ses->dfltuid = option;
>> +			v9ses->dfltuid = make_kuid(&init_user_ns, option);
>
> I think the init_user_ns should be current_user_ns() cause the value is come from userspace
> and in kernel we should mapping it to its own user_ns.

Good point.  current_user_ns() is more appropriate and maintainable.

For now you can only mount 9p when current_user_ns() == &init_user_ns
but that might change in the future.

Thanks,
Eric
