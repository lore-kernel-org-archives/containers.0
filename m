From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [CFT][PATCH] mnt: Implicitly add MNT_NODEV on remount when it was
	implicitly added by mount
Date: Sun, 30 Nov 2014 07:00:56 -0800
Message-ID: <CALCETrUZRi=Y=CDTpq5oO-tPOvMsZ+osKiydkCk-P0dn4DKJkA@mail.gmail.com>
References: <20141127101105.GA30605@linux-rxt1.site>
	<87k32dlicc.fsf@x220.int.ebiederm.org>
	<87egsllia3.fsf_-_@x220.int.ebiederm.org> <547B309E.9020706@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <547B309E.9020706-/L3Ra7n9ekc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, joeyli <jlee-IBi9RG/b67k@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Nov 30, 2014 at 6:58 AM, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> wrote:
> Eric,
>
> Am 30.11.2014 um 00:05 schrieb Eric W. Biederman:
>>
>> Now that remount is properly enforcing the rule that you can't remove
>> nodev at least sandstorm.io is breaking when performing a remount.
>>
>> It turns out that there is an easy intuitive solution implicitly
>> add nodev on remount when nodev was implicitly added on mount.
>
> Is this patch supposed to unbreak libvirt-lxc?
> At least 1.2.9 is still broken.
>

Either this patch or my variant of it fixes the libvirt-lxc breakage
that I understand, but IIRC there was some other issue that none of us
figured out at K-S.

--Andy

> Thanks,
> //richard



-- 
Andy Lutomirski
AMA Capital Management, LLC
