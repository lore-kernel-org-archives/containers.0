From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [CFT][PATCH] mnt: Implicitly add MNT_NODEV on remount when it
	was implicitly added by mount
Date: Sun, 30 Nov 2014 19:42:57 +0100
Message-ID: <547B6531.40504@nod.at>
References: <20141127101105.GA30605@linux-rxt1.site>	<87k32dlicc.fsf@x220.int.ebiederm.org>	<87egsllia3.fsf_-_@x220.int.ebiederm.org>
	<547B309E.9020706@nod.at>	<CALCETrUZRi=Y=CDTpq5oO-tPOvMsZ+osKiydkCk-P0dn4DKJkA@mail.gmail.com>	<547B34C6.6030709@nod.at>	<CALCETrW6QRRB_DfHwYv+UVJ_8yF+8Db+UP+ezd4jG599b4dSiA@mail.gmail.com>	<547B5066.4020509@nod.at>
	<871tokleo7.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tokleo7.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, joeyli <jlee-IBi9RG/b67k@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

Am 30.11.2014 um 19:35 schrieb Eric W. Biederman:
> Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:
> 
>> Am 30.11.2014 um 16:37 schrieb Andy Lutomirski:
>>> On Sun, Nov 30, 2014 at 7:16 AM, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> wrote:
>>>> Am 30.11.2014 um 16:00 schrieb Andy Lutomirski:
>>>>> On Sun, Nov 30, 2014 at 6:58 AM, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> wrote:
>>>>>> Eric,
>>>>>>
>>>>>> Am 30.11.2014 um 00:05 schrieb Eric W. Biederman:
>>>>>>>
>>>>>>> Now that remount is properly enforcing the rule that you can't remove
>>>>>>> nodev at least sandstorm.io is breaking when performing a remount.
>>>>>>>
>>>>>>> It turns out that there is an easy intuitive solution implicitly
>>>>>>> add nodev on remount when nodev was implicitly added on mount.
>>>>>>
>>>>>> Is this patch supposed to unbreak libvirt-lxc?
>>>>>> At least 1.2.9 is still broken.
>>>>>>
>>>>>
>>>>> Either this patch or my variant of it fixes the libvirt-lxc breakage
>>>>> that I understand, but IIRC there was some other issue that none of us
>>>>> figured out at K-S.
>>>>
>>>> Currently it fails here:
>>>> 2014-11-25 22:36:45.295+0000: 1: debug : virFileMakePathHelper:2436 : path=/proc mode=0777
>>>> 2014-11-25 22:36:45.295+0000: 1: debug : lxcContainerMountBasicFS:918 : Mount proc on /proc type=proc flags=e
>>>> 2014-11-25 22:36:45.296+0000: 1: debug : lxcContainerMountBasicFS:873 : Processing /proc/sys -> /proc/sys
>>>> 2014-11-25 22:36:45.296+0000: 1: debug : virFileMakePathHelper:2436 : path=/proc/sys mode=0777
>>>> 2014-11-25 22:36:45.296+0000: 1: debug : lxcContainerMountBasicFS:918 : Mount /proc/sys on /proc/sys type=(null) flags=1000
>>>> 2014-11-25 22:36:45.296+0000: 1: error : lxcContainerMountBasicFS:933 : Failed to re-mount /proc/sys on /proc/sys flags=1021: Operation not permitted
>>>
>>> Any chance you can test that with Eric's patch or mine [1] applied?
>>> If that doesn't work, can you try to catch the failure with strace?
>>
>> With your patch applied on top of Linus's tree as of today libvirt-lxc works fine again. :)
> 
> *Scratches head*
> 
> Did you really have my latest patch applied?
> 
> Andy's patch implies a change of policy that I really don't want to
> deploy as a bug fix.

Hmm, let me double check this tomorrow with a fresh brain.
Maybe I got hit by another issue while testing your patch.
Currently I'm fighting against three libvirt-lxc issues in parallel. :-\

Thanks,
//richard
