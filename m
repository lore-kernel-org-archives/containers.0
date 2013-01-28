From: Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH review 2/6] userns: Allow any uid or gid mappings that
	don't overlap.
Date: Mon, 28 Jan 2013 18:41:39 +0400
Message-ID: <51068E23.5040000__19625.5384049893$1359384110$gmane$org@parallels.com>
References: <87ehh8it9s.fsf@xmission.com> <87zjzwhegj.fsf@xmission.com>
	<20130128142816.GU17632@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130128142816.GU17632-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello Mr. Someone.

On 01/28/2013 06:28 PM, Aristeu Rozanski wrote:
> On Fri, Jan 25, 2013 at 06:21:00PM -0800, Eric W. Biederman wrote:
>> When I initially wrote the code for /proc/<pid>/uid_map.  I was lazy
>> and avoided duplicate mappings by the simple expedient of ensuring the
>> first number in a new extent was greater than any number in the
>> previous extent.
>>
>> Unfortunately that precludes a number of valid mappings, and someone
>> noticed and complained.  So use a simple check to ensure that ranges
>> in the mapping extents don't overlap.
> 
> Acked-by: Someone <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 

Documentation/SubmittingPatches:

"then you just add a line saying

        Signed-off-by: Random J Developer <random-ld4jwAGwUXQYGaZWVHDzw80vGNN6ct63@public.gmane.org>

using your real name (sorry, no pseudonyms or anonymous contributions.)"

I know how it feels, but that is how it goes. You'll have to change that.
