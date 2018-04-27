From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH v3 1/3] ima: extend clone() with IMA namespace support
Date: Thu, 26 Apr 2018 19:49:59 -0500
Message-ID: <87fu3hbhhk.fsf__9253.11472169614$1524790097$gmane$org@xmission.com>
References: <1522159038-14175-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1522159038-14175-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87sh8lcecn.fsf@xmission.com>
	<1523636702.3272.63.camel@linux.vnet.ibm.com>
	<d8c30d7d-c679-9323-7a25-d3148e9b96c6@canonical.com>
	<1524081472.3272.319.camel@linux.vnet.ibm.com>
	<87wox4s282.fsf@xmission.com>
	<8895cb9c-7b9e-2f82-e3d8-a15f5fc26e25@canonical.com>
	<2103bbb9-3f2a-78f8-f7ad-28859659973f@linux.vnet.ibm.com>
	<f84ae8af-fa5b-9f31-fbef-5a49f90dd45a@canonical.com>
	<0d2b2635-d7fb-d240-7dd0-2a81014c58ba@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0d2b2635-d7fb-d240-7dd0-2a81014c58ba-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> (Stefan
	Berger's message of "Thu, 26 Apr 2018 17:18:43 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> On 04/19/2018 11:35 AM, John Johansen wrote:

>> It sounds like its already decided, with ima and selinux going with an unshare file within their own fs.
>>
>> AppArmor went a different route already, splitting namespace creation (mkdir in the apparmorfs policy/namespace dir) and the task entering the namespace with a write apparmor's equiv of setexeccon.
>>
> I am supporting procfs entries for the IMA namespace spawned by writing a
> boolean '1' into IMA's securityfs 'unshare' file. It would allow to use
> setns(fd, 0), obviously with the 0 parameter. I think this is an important
> function to support considering entering a set of namespace. I am just wondering
> about the 0 parameter. We don't have a CLONE flag for it, so there's not other
> way to support it then. Does it matter ?

That should be fine.  We can pick a flag for setns at some point for
IMA.  The setns function uses the flag field as an enumeration so any of
the low 8 bits or a combination with overlapping bit is valid to setns.

Eric
