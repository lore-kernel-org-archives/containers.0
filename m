From: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Subject: Fwd: Re: lxc-performance?
Date: Fri, 08 Oct 2010 10:09:51 +0200
Message-ID: <4CAED1CF.6050908@univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



-------- Message original --------
Sujet: 	Re: lxc-performance
Date : 	Thu, 07 Oct 2010 16:56:05 +0200
De : 	MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Pour : 	MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>



Le 07/10/2010 16:43, MALATTAR a =E9crit :
> ------------------------------------------------------------------------
> 06.10.2010 23:41, MALATTAR ?????:
>
> >/  the container dora1, where i launch an instance of my IDS, does not t=
ake
> />/  more than 70 MB as memory even though the memory limit for it is much
> />/  bigger than this value,
> /
> How do you measure memory usage?

by using the command:
lxc-cgroup -n dora1 memory.usage_in_bytes
>   What's in memory.max_usage_in_bytes of
> the container's cgroup?
executing the next command lxc-cgroup -n dora1 memory.max_usage_in_bytes
gave me 70193152 bytes

> -- =

> Mouhannad AlATTAR
> Doctorant =E0 L'UFR Sciences,Techniques et Gestion de l'Industrie
> P=F4le multimedia de Franche Comt=E9 - numerica
> 1, cours Leprince-Ringuet
> 25201 Montb=E9liard
> Fixe bureau : 03 81 99 47 87
> Portable : 06 16 71 05 10
>
>


-- =

Mouhannad AlATTAR
Doctorant =E0 L'UFR Sciences,Techniques et Gestion de l'Industrie
P=F4le multimedia de Franche Comt=E9 - numerica
1, cours Leprince-Ringuet
25201 Montb=E9liard
Fixe bureau : 03 81 99 47 87
Portable : 06 16 71 05 10
