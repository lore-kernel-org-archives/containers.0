From: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 0/2] userns: automount cleanups
Date: Thu, 30 Nov 2017 17:11:26 +0800
Message-ID: <bdda8d98-644e-9ce6-f858-9f751d2fe92c@themaw.net>
References: <874lpck52r.fsf@xmission.com>
	<c5174597-ab58-9b71-e6e9-6b15d256f22c@themaw.net>
	<877eu8ibor.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <877eu8ibor.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

On 30/11/17 13:21, Eric W. Biederman wrote:
> Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org> writes:
> 
>> On 30/11/17 08:01, Eric W. Biederman wrote:
>>>
>>> While reviewing some code I realized that in getting d_automount working
>>> with s_user_ns I had left behind some unnecessary relics of the blind
>>> path I started down.  Here are two patches that remove those relics.
>>>
>>> Unless someone has another preference I will drop them in my userns tree
>>> and merge them that way.
>>
>> I saw the "<etc>->s_user_ns != &init_user_ns" and wondered if that would
>> trigger for automount(8) run entirely with a container (eg. docker)?
> 
> autofs still needs FS_USERNS_MOUNT before you can reach that point.  But
> docker does have a mode ?--userns-remap? where it sets up the containers
> mounts that way.
> 
> I think in principle that should work and be safe.  I don't know how
> robust autofs is against malicious users.  Which is the question to ask
> before actually adding FS_USERNS_MOUNT in struct file_system_type.

automount(8) thinks it is running as uid 0 (which it is in the container)
so this would require a bit of thought since automount(8) doesn't take
special precautions.

The restrictions, in the case of running entirely within a container, are
those of the container itself. For example, if there are no granular
capabilities available then the admin needs to run the container as
privileged in order to be able to mount NFS file systems, which is a
common usage case. 

Ian
